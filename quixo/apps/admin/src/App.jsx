import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import AdminLogin        from './pages/Auth/AdminLogin';
import AdminRoute        from './guards/AdminRoute';
import Dashboard         from './pages/Dashboard/index';
import VendorApproval    from './pages/Approvals/VendorApproval';
import RiderApproval     from './pages/Approvals/RiderApproval';
import VendorList        from './pages/VendorManagement/VendorList';
import VendorDetail      from './pages/VendorManagement/VendorDetail';
import RiderList         from './pages/RiderManagement/RiderList';
import RiderDetail       from './pages/RiderManagement/RiderDetail';
import ClientList        from './pages/ClientManagement/ClientList';
import ClientDetail      from './pages/ClientManagement/ClientDetail';
import SuspendCustomer   from './pages/ClientManagement/SuspendCustomer';
import ProductApproval   from './pages/ProductManagement/ProductApproval';
import ProductList       from './pages/ProductManagement/ProductList';
import OrderList         from './pages/OrderManagement/OrderList';
import EmployeeList      from './pages/Employee/EmployeeList';
import AddEmployee       from './pages/Employee/AddEmployee';
import Payroll           from './pages/Employee/Payroll';
import AnalyticsPage     from './pages/Analytics/AnalyticsPage';
import InvoicePage       from './pages/Invoices/InvoicePage';
import CategoryList      from './pages/Categories/CategoryList';
import CreateCategory    from './pages/Categories/CreateCategory';

const App = () => (
  <Routes>
    <Route path="/login" element={<AdminLogin />} />
    <Route element={<AdminRoute />}>
      <Route path="/"                      element={<Dashboard />} />
      <Route path="/approvals/vendors"     element={<VendorApproval />} />
      <Route path="/approvals/riders"      element={<RiderApproval />} />
      <Route path="/vendors"               element={<VendorList />} />
      <Route path="/vendors/:id"           element={<VendorDetail />} />
      <Route path="/riders"                element={<RiderList />} />
      <Route path="/riders/:id"            element={<RiderDetail />} />
      <Route path="/clients"               element={<ClientList />} />
      <Route path="/clients/:id"           element={<ClientDetail />} />
      <Route path="/clients/:id/suspend"   element={<SuspendCustomer />} />
      <Route path="/products/approval"     element={<ProductApproval />} />
      <Route path="/products"              element={<ProductList />} />
      <Route path="/orders"                element={<OrderList />} />
      <Route path="/employees"             element={<EmployeeList />} />
      <Route path="/employees/add"         element={<AddEmployee />} />
      <Route path="/employees/payroll"     element={<Payroll />} />
      <Route path="/analytics"             element={<AnalyticsPage />} />
      <Route path="/invoices"              element={<InvoicePage />} />
      <Route path="/categories"            element={<CategoryList />} />
      <Route path="/categories/create"     element={<CreateCategory />} />
    </Route>
    <Route path="*" element={<Navigate to="/login" />} />
  </Routes>
);
export default App;